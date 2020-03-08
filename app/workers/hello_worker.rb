class HelloWorker
  include Sidekiq::Worker

  def perform
    puts 'hello'
  end
end
