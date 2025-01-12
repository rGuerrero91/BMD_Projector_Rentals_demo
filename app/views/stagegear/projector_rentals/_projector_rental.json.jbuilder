json.extract! projector_rental,
              :id,
              :start_date,
              :end_date,
              :client_id,
              :projector_id,
              :status,
              :created_at,
              :updated_at
json.url projector_rental_url(projector_rental, format: :json)
