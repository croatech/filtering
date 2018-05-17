class Filtering::Base
  def initialize(params, args = {})
    @plain_params = params.permit(plain_acessible_params)
    @complex_params = params.permit(complex_acessible_params)
    @page = args[:page]
    @results = relation
  end

  def call
    raise "@relation not initialized at #{self.class.name}. Add @relation = Offer for example." if relation.nil?

    filter_by_plain_params unless plain_params.empty?
    filter_by_complex_params unless complex_params.empty?

    return results.page(page) if results.respond_to?(:page)
    results
  end

  protected

  attr_reader :plain_params, :complex_params, :page, :results

  def relation
    raise 'relation method not implemented. Add this method to calling class and add AR relation, for example Model.all'
  end

  def plain_acessible_params
    []
  end

  def complex_acessible_params
    []
  end

  private

  def filter_by_plain_params
    plain_params.each do |key, value|
      @results = results.where("#{key}": value) if value.present?
    end
  end

  def filter_by_complex_params
    raise_if_complex_method_not_implemented

    complex_params.each do |key, value|
      @results = send("filter_by_#{key}", value)
    end
  end

  def raise_if_complex_method_not_implemented
    complex_acessible_params.each do |param|
      method_name = "filter_by_#{param}"
      raise "#{method_name} method not implemented. Add #{method_name} private method to #{self.class.name} or remove #{param} param from complex_acessible_params" unless self.private_methods.include?(method_name.to_sym)
    end
  end
end