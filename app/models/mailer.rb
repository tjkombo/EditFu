class Mailer < ActionMailer::Base
  def signup(user)
    setup   user
    subject "Welcome to EditFu. Now meet the ninjas."
  end

  def editor_invitation(user)
    setup   user
    subject "Content editor invitation."
  end

  def reset_password(user)
    setup   user
    subject "Reset edit-fu password"
  end

  def plan_change(user)
    setup   user
    subject 'EditFu plan change.'  
  end

  def credit_card_changes(user)
    setup   user
    subject 'EditFu credit card changes.'
  end

  def account_cancellation(user)
    setup   user
    subject 'EditFu account cancellation.'
  end

  def admin_subdomain_changes(user)
    setup   user
    subject 'EditFu subdomain changes.'
  end

  def editor_subdomain_changes(owner, editor)
    setup   editor
    subject 'Content editing system address changes.'
    body    :owner => owner, :editor => editor
  end

  def owner_email_changes(user)
    setup   user
    subject 'EditFu email address.'
  end

  def editor_email_changes(user)
    setup   user
    subject 'Content editing system email address change.'
  end

  private

  def setup(user)
    from         "edit.fu.cms@gmail.com"
    recipients   user.email
    content_type 'text/html'
    body         :user => user
  end
end
