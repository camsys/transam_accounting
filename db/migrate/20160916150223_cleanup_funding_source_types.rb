class CleanupFundingSourceTypes < ActiveRecord::Migration
  def change
    funding_source_types = [
        {:id => 1, :active => 1, :name => 'Federal',  :description => 'Federal Funding Source'},
        {:id => 2, :active => 1, :name => 'State',    :description => 'State Funding Source'},
        {:id => 3, :active => 1, :name => 'Local',    :description => 'Local Funding Source'},
        {:id => 4, :active => 1, :name => 'Agency',    :description => 'Agency Funding Source'},
        {:id => 5, :active => 1, :name => 'Other',    :description => 'Other Funding Source'}
    ]

    FundingSourceType.destroy_all
    funding_source_types.each do |type|
      FundingSourceType.create(type)
    end

    puts "Funding sources currently linked may have the wrong source type"
  end
end
