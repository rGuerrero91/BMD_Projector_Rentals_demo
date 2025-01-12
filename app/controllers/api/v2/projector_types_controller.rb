class API::V2::ProjectorTypesController < API::V2::BaseResourceController
  before_action :parse_dates, only: :index

  def index
    available_projectors = StageGear::Projector.available_on_dates(@start_date, @end_date)
    available_types = available_projectors.map(&:projector_type).uniq
    data_types = format_projector_types(available_types)

    render json: { data: data_types }
  end

  private

  def parse_dates
    filter_params = params.require(:filter).permit(:start, :end)
    @start_date = Date.strptime(filter_params[:start])
    @end_date = Date.strptime(filter_params[:end])
  end

  def format_projector_types(types)
    types.map do |type|
      { id: type.id.to_s, type: "projector-types", attributes: { name: type.name } }
    end
  end
end
