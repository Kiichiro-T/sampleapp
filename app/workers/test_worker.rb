class TestWorker
  include Sidekiq::Worker

  def perform
    puts "test"
  end
end
