module SystangoHrmTeamleadsHelper

	include SystangoHrm::WelcomeHelperPatch

  def principal_check_box_tag(name, principals)
    s = ''
    principals.sort.each do |principal|
      s << "<label>#{ check_box_tag name, principal.id, false } #{h principal}</label>"
    end
    s.html_safe
  end

end
