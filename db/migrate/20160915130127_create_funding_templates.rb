class CreateFundingTemplates < ActiveRecord::Migration
  def change
    create_table :funding_templates do |t|
      t.string :object_key,         index: true, limit: 12, null: false
      t.references :funding_source, index: true
      t.string :name,               limit: 64, null: false
      t.text :description
      t.references :contributer,    index: true, null: false
      t.references :owner,          index: true, null: false
      t.boolean :recurring
      t.boolean :transfer_only
      t.float :match_required
      t.boolean :active,            null: false

      t.timestamps
    end

    create_table :funding_template_types do |t|
      t.references :funding_source, index: true
      t.string :name,               limit: 64, null: false
      t.string :description,        limit: 256, null: false
      t.boolean :active,            null:false
    end

    create_table :funding_templates_funding_template_types, :id => false do |t|
      t.references :funding_template
      t.references :funding_template_type
    end

    add_index :funding_templates_funding_template_types, :funding_template_id, name: 'funding_templates_funding_template_types_idx1'
    add_index :funding_templates_funding_template_types, :funding_template_type_id, name: 'funding_templates_funding_template_types_idx2'

    create_table :funding_templates_organizations, :id => false do |t|
      t.references :funding_template,       index: true
      t.references :organization,           index: true
    end

    # add seed data
    funding_template_types = [
        {:active => 1, :name => 'Capital', :description => 'Capital Funding Template'},
        {:active => 1, :name => 'Debt Service', :description => 'Debt Service Funding Template'},
        {:active => 1, :name => 'Operating', :description => 'Operating Funding Template'},
        {:active => 1, :name => 'Other', :description => 'Other Funding Template'},
    ]
    funding_template_types.each do |type|
      FundingTemplateType.create(type)
    end
  end
end
