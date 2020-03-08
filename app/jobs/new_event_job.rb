class NewEventJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts 'new_event_test'
  end
end
