configure :production do
  set :port, ENV['PORT'] || 9292
  set :bind, '0.0.0.0'
  
  # Enable CORS for GitHub Pages
  before do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS'
    headers 'Access-Control-Allow-Headers' => 'Content-Type, Authorization'
  end
  
  options '*' do
    200
  end
end

configure :development do
  set :port, 3000
  set :bind, 'localhost'
end