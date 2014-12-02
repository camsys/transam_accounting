namespace :transam do
  desc "Updates the book value of every asset"
  task update_book_value: :environment do
    Asset.all.each do |a|
      a.update_book_value
    end
  end
end
