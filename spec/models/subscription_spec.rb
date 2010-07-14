require 'spec_helper'

describe Subscription do

  should_belong_to :owner
  should_validate_presence_of :start_at, :end_at, :price

end


# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  owner_id   :integer(4)
#  start_at   :date
#  end_at     :date
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer(4)
#

