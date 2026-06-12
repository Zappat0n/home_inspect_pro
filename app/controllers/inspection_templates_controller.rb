# frozen_string_literal: true

class InspectionTemplatesController < ApplicationController
  before_action :require_subscription, except: %i[index show]

  def index
    system_templates = InspectionTemplate.system_templates.published.where(country: current_user.country)
    custom_templates = current_user.inspection_templates.custom_templates

    render(
      locals: {
        system_templates: system_templates,
        custom_templates: custom_templates,
      },
    )
  end

  def show
    render(locals: { template: template })
  end

  def new
    tpl = current_user.inspection_templates.build(
      template_type: :custom,
      country: current_user.country,
    )
    render(locals: { template: tpl })
  end

  def create
    tpl = current_user.inspection_templates.build(
      template_params.merge(
        template_type: :custom,
        country: current_user.country,
      ),
    )

    if tpl.save
      redirect_to(
        inspection_template_path(tpl),
        notice: t("inspection_templates.create.success"),
      )
    else
      render(
        :new,
        locals: { template: tpl },
        status: :unprocessable_content,
      )
    end
  end

  def duplicate
    source = InspectionTemplate.published.find(params[:id])
    new_template = TemplateDuplicationService
      .new(source, current_user)
      .call
    redirect_to(
      edit_inspection_template_path(new_template),
      notice: t("inspection_templates.duplicate.success"),
    )
  rescue ActiveRecord::RecordNotFound
    redirect_to(
      inspection_templates_path,
      alert: t("inspection_templates.duplicate.not_found"),
    )
  end

  def edit
    unless editable?
      return redirect_to(
        inspection_templates_path,
        alert: t("inspection_templates.not_authorized"),
      )
    end

    render(locals: { template: template })
  end

  def update
    unless editable?
      return redirect_to(
        inspection_templates_path,
        alert: t("inspection_templates.not_authorized"),
      )
    end

    if template.update(template_params)
      redirect_to(
        inspection_template_path(template),
        notice: t("inspection_templates.update.success"),
      )
    else
      render(
        :edit,
        locals: { template: template },
        status: :unprocessable_content,
      )
    end
  end

  def destroy
    unless editable?
      return redirect_to(
        inspection_templates_path,
        alert: t("inspection_templates.not_authorized"),
      )
    end

    if template.inspections.exists?
      redirect_to(
        inspection_templates_path,
        alert: t("inspection_templates.destroy.in_use", count: template.inspections.count),
      )
    else
      template.destroy!
      redirect_to(
        inspection_templates_path,
        notice: t("inspection_templates.destroy.success"),
      )
    end
  end

  private

  def template
    @_template ||= InspectionTemplate.find(params[:id])
  end

  def editable?
    template.user == current_user && template.custom?
  end

  def template_params
    params.expect(inspection_template: [:name])
  end
end
