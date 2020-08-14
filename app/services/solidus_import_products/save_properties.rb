module SolidusImportProducts
  class SaveProperties
    attr_accessor :product, :properties_hash, :logger

    def self.call(options = {})
      new.call(options)
    end

    def call(args = { product: nil, properties_hash: nil })
      self.logger = SolidusImportProducts::Logger.instance
      self.properties_hash = args[:properties_hash]
      self.product = args[:product]

      properties_hash.each do |field, value|
        normalized_property_name = field.to_s.downcase
        property = Spree::Property.where(name: normalized_property_name).first

        unless property
          logger.log(
            "INFO: Creating new Spree::Property: #{normalized_property_name}",
            :info
          )

          property = Spree::Property.create(
            name: normalized_property_name,
            presentation: field.to_s.capitalize
          )
        end

        next unless property

        product_property = Spree::ProductProperty.where(product_id: product.id, property_id: property.id).first_or_initialize
        logger.log("INFO: Existing ProductProperty: #{product_property}", :info)
        product_property.value = value
        product_property.save!
      end
    end
  end
end
