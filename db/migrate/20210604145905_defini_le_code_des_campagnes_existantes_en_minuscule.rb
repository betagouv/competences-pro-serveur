class DefiniLeCodeDesCampagnesExistantesEnMinuscule < ActiveRecord::Migration[6.1]
  def up
    Campagne.find_each do |campagne|
      campagne.update!(code: campagne.code.downcase)
    end
  end
end
