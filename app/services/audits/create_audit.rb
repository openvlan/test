module Audits
  class CreateAudit
    def initialize(model:, field:)
      @model = model
      @field = field
    end

    def create(audited:, original_value:, new_value:, user_id:, message: '')
      params = {
        audited: audited,
        audited_type: @model,
        field: @field,
        original_value: original_value,
        new_value: new_value,
        user_id: user_id,
        message: message
      }
      Audit.create!(params)
    end
  end
end
