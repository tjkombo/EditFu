class Owner

  after_update :deliver_changes,               :if => :valid?
  after_destroy :account_cancellation

  def self.deliver_scheduled_messages
    deliver_card_expirations
    deliver_cards_have_expired
    deliver_trial_expiration_reminder
    deliver_trial_expirations
    deliver_holded_status
  end
  
  def self.deliver_next_week_report
    weeks_owners = Subscription.ends_earlier_than(1.week).map(&:owner)
    days_owners = Subscription.ends_earlier_than(1.day).map(&:owner)
    todays_owners = Subscription.ends_todays.map(&:owner)

    todays_owners.each do |owner|
      owner.create_automatic_next_subscription
    end

    Mailer.deliver_hold_report(:weeks_owners => weeks_owners, :days_owners => days_owners, :todays_owners => todays_owners)
  end
  
  def send_confirmation_instructions
    Mailer.deliver_signup(self)
  end
  
  def deliver_hold
    Mailer.deliver_hold(self)
  end
  
  protected
  
  def deliver_changes
    deliver_subdomain_changes     if domain_name_changed?
    deliver_owner_email_changes   if email_changed?
    deliver_plan_changed          if plan_changed?
  end
  
  
  def deliver_plan_changed
    Mailer.deliver_plan_change(self)
  end
  
  def deliver_subdomain_changes
    Mailer.deliver_owner_subdomain_changes(self)
    editors.each do |editor|
      Mailer.deliver_editor_subdomain_changes(self, editor)
    end
  end
  
  def account_cancellation
    Mailer.deliver_account_cancellation(self)
  end
  
  def deliver_owner_email_changes
    Mailer.deliver_owner_email_changes(self)
  end
  
  def self.deliver_card_expirations
    Card.find_all_by_display_expiration_date(15.days.from_now.to_date).map(&:owner).each do |owner|
      Mailer.deliver_card_expiration(owner)
    end
  end

  def self.deliver_cards_have_expired
    Card.find_all_by_display_expiration_date(Date.today).map(&:owner).each do |owner|
      Mailer.deliver_card_has_expired(owner)
    end
  end

  def self.deliver_trial_expirations
    owners = Subscription.ends_todays.scoped(:conditions => ["plan_id = ?", Plan::TRIAL.id]).map(&:owner)
    owners.each do |owner|
      Mailer.deliver_trial_expiration(owner)
    end
  end
  
  def self.deliver_trial_expiration_reminder
    owners = Subscription.ends_earlier_than(3.days).scoped(:conditions => ["plan_id = ?", Plan::TRIAL.id]).map(&:owner)
    owners.each do |owner|
      Mailer.deliver_trial_expiration_reminder(owner)
    end
  end
  
  def self.deliver_holded_status
    owners = Owner.find(:all, :include => [:subscriptions]).select do |o|
      o.subscriptions.last.ends_at.to_date == Date.tomorrow
    end
    
    owners.each do |o|
      Mailer.deliver_tomorrow_holded_status(o)
    end
  end
  
  
end