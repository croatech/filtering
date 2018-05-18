class Filtering::Base
  def initialize(params, args = {})
    @plain_params = permit(params, plain_acessible_params)
    @complex_params = permit(params, complex_acessible_params)
    @page = args[:page]
    @order = args[:order]
  end

  def call
    @result = relation

    filter_by_plain_params unless plain_params.empty?
    filter_by_complex_params unless complex_params.empty?

    paginate if result.respond_to?(:page)
    ordering if order.present?
    grouping if group.present?

    return result
  end

  protected

  attr_reader :plain_params, :complex_params, :page, :order, :group, :result

  def relation
    raise 'relation method not implemented. Add this method to calling class and add AR relation, for example Model.all'
  end

  def permit(params, acessible_params)
    return {} if acessible_params.nil?

    if params.respond_to?(:permit)
      params.permit(acessible_params)
    else
      params.symbolize_keys.slice(*acessible_params.map(&:to_sym))
    end
  end

  def plain_acessible_params; end

  def complex_acessible_params; end

  private

  def filter_by_plain_params
    return if plain_params.empty?

    plain_params.each do |key, value|
      @result = result.where("#{key}": value) if value.present?
    end
  end

  def filter_by_complex_params
    return if complex_params.empty?

    raise_if_complex_method_not_implemented

    complex_params.each do |key, value|
      @result = send("filter_by_#{key}", value)
    end
  end

  def raise_if_complex_method_not_implemented
    complex_acessible_params.each do |param|
      method_name = "filter_by_#{param}"
      raise "#{method_name} method not implemented. Add #{method_name} private method to #{self.class.name} or remove #{param} param from complex_acessible_params" unless self.private_methods.include?(method_name.to_sym)
    end
  end

  def paginate
    @result = result.page(page)
  end

  def ordering
    @result = result.order(order)
  end

  def grouping
    @result = result.group(group)
  end
end