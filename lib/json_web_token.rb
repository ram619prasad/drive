class JsonWebToken
  def self.encode(payload, browser: 'NA', exp: 1.day.from_now)
    payload = payload.with_indifferent_access
    payload[:exp] = exp.to_i
    encoded_token = JWT.encode(payload, ENV['SECRET_KEY'])
    REDIS_CLIENT.hmset(payload[:id], browser, encoded_token)

    encoded_token
  end

  def decode(token, browser: 'NA')
    body = JWT.decode(token, ENV['SECRET_KEY'])[0]
    HashWithIndifferentAccess.new body
  rescue
    nil
  end
end
