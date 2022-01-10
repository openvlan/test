class DynamicLinksService
  def create_link(route)
    "#{dynamic_link}/?link=#{redirect_link}"\
    "#{route}&ofl=#{desktop_link}"\
    "&apn=#{apn}"\
    "&isi=#{isi}"\
    "&ibi=#{ibi}"
  end

  def dynamic_link
    @dynamic_link ||= Rails.application.secrets.app_dynamic_link
  end

  def redirect_link
    @redirect_link ||= Rails.application.secrets.app_redirect_link
  end

  def desktop_link
    @desktop_link ||= Rails.application.secrets.app_desktop_link
  end

  def apn
    @apn ||= Rails.application.secrets.firebase_dynamic_link_apn
  end

  def isi
    @isi ||= Rails.application.secrets.firebase_dynamic_link_isi
  end

  def ibi
    @ibi ||= Rails.application.secrets.firebase_dynamic_link_ibi
  end
end
