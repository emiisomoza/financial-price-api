module Fixtures
  def fx_response
    { "result" => "success", "rates" => { "AUD" => 1.55 } }.to_json
  end

  def crypto_response
    { "bitcoin" => { "aud" => 98000.0 } }.to_json
  end

  def stock_response
    { "c" => 180.0 }.to_json
  end

  def fx_usd_aud_response
    { "result" => "success", "rates" => { "AUD" => 1.55 } }.to_json
  end
end