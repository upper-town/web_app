# frozen_string_literal: true

module CodeGenerator
  ALPHABET = %w[
    A B C D E F G H   J K L M N   P Q R S T U   W X Y Z
      1 2 3 4 5 6 7 8 9
  ]

  SECRET = Rails.application.key_generator.generate_key(ENV.fetch("CODE_SALT"))

  extend self

  def generate(length = 8, secret = SECRET)
    code = Array.new(length) { ALPHABET[SecureRandom.random_number(32)] }.join
    code_digest = digest(code, secret)

    [code, code_digest]
  end

  def digest(code, secret = SECRET)
    OpenSSL::HMAC.hexdigest("sha256", secret, code)
  end
end
