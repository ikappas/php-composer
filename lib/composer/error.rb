module Composer
  class Error < ::StandardError; end
  class ArgumentError < Error; end
  class TypeError < Error; end
  class UnexpectedValueError < Error; end
  class LogicError < Error; end
  class InvalidRepositoryError < Error; end
end
