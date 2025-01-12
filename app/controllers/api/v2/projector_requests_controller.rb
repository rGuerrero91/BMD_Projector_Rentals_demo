class API::V2::ProjectorRequestsController < API::V2::BaseController
  before_action :authenticate_staff
  before_action :fetch_prices, only: :create

  def create
    projector_request =
      StageGear::ProjectorRequest.new(request_params.except(%i[coi drivers_license]))
    client = projector_request.create_or_find_client
    projector = projector_request.find_best_projector
    rental = projector_request.create_rental(client, projector)

    if rental.save
      rental.order_confirmation
      client.coi.attach(request_params[:coi])
      client.drivers_license.attach(request_params[:drivers_license])

      if client.save
        render json: { success: true, rental_id: rental.id }, status: :created
      else
        client.coi.purge_later
        client.drivers_license.purge_later
        render json: { success: false, error: client.errors }, status: :unprocessable_entity
      end
    else
      render json: { success: false, error: rental.errors }, status: :unprocessable_entity
    end
  end

  # POST /projector_requests/cancel?rental_id=:id
  def cancel
    rental = StageGear::ProjectorRental.find(params[:rental_id])
    if rental.update(status: "cancelled")
      rental.projector.update(status: "available")
      render json: { success: true }, status: :ok
    else
      render json: { success: false, error: rental.errors }, status: :unprocessable_entity
    end
  end

  private

  def fetch_prices
    @prices = Rails.configuration.x.stripe.prices.fetch(:catalog, {})[:projector]
  end

  def request_params
    params.require(:projector_request).permit(
      %i[
        projector_type
        start_date
        end_date
        first_name
        last_name
        organization
        email
        street_address
        city
        state
        postal_code
        payment_type
        coi
        drivers_license
        purchase_order
        success_url
        cancel_url
      ]
    )
  end
end
