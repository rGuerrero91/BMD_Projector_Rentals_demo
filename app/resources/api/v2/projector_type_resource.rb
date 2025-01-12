class API::V2::ProjectorTypeResource < JSONAPI::Resource
  model_name "StageGear::ProjectorType"
  immutable
  caching

  attributes :name

  filter :start, apply: ->(records, value, _options) { records }
  filter :end, apply: ->(records, value, _options) { records }
end
