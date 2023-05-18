module SpreeMercadoPago
  VERSION = '0.1.7'.freeze

  module_function

  # Returns the version of the currently loaded SpreeMercadoPago as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
