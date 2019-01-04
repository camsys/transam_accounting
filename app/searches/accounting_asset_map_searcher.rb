# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class TransitAssetMapSearcher < BaseSearcher

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  def self.form_params
    [
        :sourceable_id,
        # Comparator-based (<=>)
        :book_value,
        :book_value_comparator
    ]
  end

  private

  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------

  def sourceable_conditions
    clean_sourceable_id = remove_blanks(sourceable_id)

    unless clean_sourceable_id.empty?
      grant_purchase_asset_ids = GrantPurchase.where(sourceable_id: clean_sourceable_id, sourceable_type: GrantPurchase::SOURCEABLE_TYPE).pluck(:asset_id)
      @klass.where('id IN (?)', grant_purchase_asset_ids).distinct
    end
  end

  def book_value_conditions
    unless book_value.blank?
      book_value_as_int = sanitize_to_int(book_value)
      case book_value_comparator
        when "-1" # Less than X miles
          @klass.where("book_value < ?", book_value_as_int)
        when "0" # Exactly X miles
          @klass.where("book_value = ?", book_value_as_int)
        when "1" # Greater than X miles
          @klass.where("book_value > ?", book_value_as_int)
      end
    end
  end


  # Removes empty spaces from multi-select forms

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end

end
