class Mailer < PostageApp::Mailer

  default :from => "no-reply@livingtranscript.com"

  def recommendation_request(params = {})
    raise "request_user is a required param" if !params.include?(:request_user)
    raise "recommendation_user is a required param" if !params.include?(:recommendation_user)
    raise "uuid is a required param" if !params.include?(:uuid)

    url = "#{params[:request][:protocol]}#{params[:request][:host]}"
    url << ":#{params[:request][:port]}" if params[:request].include?(:port)
    url << "/recommendations/new/#{params[:uuid]}?auth_token=#{params[:recommendation_user].authentication_token}"

    headers['Reply-To'] = 'no-reply@livingtranscript.com'
    # PostageApp specific elements:
    postageapp_template 'recommendation_request_new_user'
    postageapp_variables 'request_user' => params[:request_user].full_name,
            'auto_login_url' => url, 'entry_title' => params[:entry_title],
            'recommendation_message' => params[:recommendation_message]

    mail(
      :from     => 'no-reply@livingtranscript.com',
      :subject  => "#{params[:request_user].full_name} Requests Feedback on Living Transcript",
      :to       => {
        params[:recommendation_user].email => {}
      })
  end

  def suggested_entry(params={})
    raise "request_user is a required param" if !params.include?(:request_user)
    raise "suggested_user is a required param" if !params.include?(:suggested_user)
    raise "suggested_entry_title is a required param" if !params.include?(:suggested_entry_title)

    url = "#{params[:request][:protocol]}#{params[:request][:host]}"
    url << ":#{params[:request][:port]}" if params[:request].include?(:port)

    headers['Reply-To'] = 'no-reply@livingtranscript.com'
    # PostageApp specific elements:
    postageapp_template 'entry_suggestion'
    postageapp_variables 'request_user' => params[:request_user].full_name,
            'url' => url,
            'suggested_title' => params[:suggested_entry_title]

    mail(
      :from     => 'no-reply@livingtranscript.com',
      :subject  => "#{params[:request_user].full_name} Suggested an Entry for your Living Transcript",
      :to       => {
        params[:suggested_user].email => {}
      })
  end

  def recommendation_notification(params={})
    url = "#{params[:request][:protocol]}#{params[:request][:host]}"
    url << ":#{params[:request][:port]}" if params[:request].include?(:port)

    headers['Reply-To'] = 'no-reply@livingtranscript.com'
    # PostageApp specific elements:
    postageapp_template 'recommendation_notification'
    postageapp_variables 'recommender_email' => params[:recommendation_user].email,
            'return_url' => url

    mail(
      :from     => 'no-reply@livingtranscript.com',
      :to       => {
        params[:entry_user].email => {}
      })
  end

  def reset_password_instructions(user)
    postageapp_template 'reset_password_instructions'
    postageapp_variables 'url' => edit_user_password_url(user, :reset_password_token => user.reset_password_token)

    mail(
      :from     => 'no-reply@livingtranscript.com',
      :subject  => "Reset Your Password on Living Transcript",
      :to       => {
        user.email => {}
      })
  end
end
