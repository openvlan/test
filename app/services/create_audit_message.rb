class CreateAuditMessage
  prepend Service::Base

  # rubocop:todo Metrics/ParameterLists
  def initialize(id, type, comment, username, associated_id = nil, associated_type = nil, audited_changes = nil)
    # rubocop:enable Metrics/ParameterLists
    @id = id
    @type = type
    @comment = comment
    @username = username
    @associated_id = associated_id
    @associated_type = associated_type
    @audited_changes = audited_changes
  end

  def call
    create_audit_message
  end

  private

  def create_audit_message
    @audit = Audited::Audit.new(action: 'update', auditable_id: @id, auditable_type: @type,
                                comment: @comment,
                                # rubocop:todo Layout/LineLength
                                username: @username, associated_id: @associated_id, associated_type: @associated_type, audited_changes: @audited_changes)
    # rubocop:enable Layout/LineLength

    return if errors.any?

    return @audit if @audit.save!

    errors.add_multiple_errors(@audit.errors.messages)
  end
end
