class StageGear::ProjectorRentalsController < BackstageController
  before_action :set_client, only: %i[new]
  before_action :set_projector_rental, only: %i[show edit update destroy]

  # GET /projector_rentals
  def index
    @projector_rentals = StageGear::ProjectorRental.all
    @projector_rentals
  end

  # GET /projector_rentals/1
  def show
    @projector_rental.projector
  end

  # GET /projector_rentals/new
  def new
    @projector_rental = StageGear::ProjectorRental.new
  end

  # GET /projector_rentals/1/edit
  def edit
  end

  # POST /projector_rentals
  def create
    @projector_rental = StageGear::ProjectorRental.new_with_projector(projector_rental_params)

    if @projector_rental.save
      redirect_to @projector_rental, notice: "Projector rental was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /projector_rentals/1
  def update
    if @projector_rental.update(projector_rental_params)
      redirect_to @projector_rental, notice: "Projector rental was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /projector_rentals/1
  def destroy
    redirect_to projector_rentals_url, notice: "Projector rental was successfully destroyed."
  end

  # Custom controllers for html Views:
  #-------------------------------------------------------------
  def confirm
    rental = StageGear::ProjectorRental.find(params[:id])
    if rental.status == "pending"
      rental.order_confirmation
    elsif rental.status == "reserved"
      rental.order_shipped
    end
    redirect_back(fallback_location: root_path, notice: "Projector rental status updated.")
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_projector_rental
    @projector_rental = StageGear::ProjectorRental.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def projector_rental_params
    params.require(:stagegear_projector_rental).permit(
      :start_date,
      :end_date,
      :client_id,
      :projector_type,
      :projector_id,
      :purchase_order,
      address: {
      }
    )
  end
end
