json.extract! projector,
              :id,
              :projector_type,
              :status,
              :unit_number,
              :manual,
              :serial_number,
              :lens_serial_number,
              :created_at,
              :updated_at
json.url projector_url(projector, format: :json)
