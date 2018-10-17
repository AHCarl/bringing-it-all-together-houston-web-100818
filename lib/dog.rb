class Dog 
  
  attr_accessor :id, :name, :breed
  
  def initialize(args)
    args.each {|k, v| self.send(("#{k}="), v)} 
  end
  
  def self.create_table 
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table 
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end 
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end
  
  def save 
    if self.id 
      self.update 
    else  
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self.class.new_from_db(@id)
    end
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first 
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.create(hash)
    creation = Dog.new(hash)
    creation.save
    creation
  end
  
  def self.find_by_id(num)
    sql = "SELECT * FROM dogs WHERE id = ?"
    
    DB[:conn].execute(sql, num).map {|row| self.new_from_db(row)}.first
  end
  
  def self.find_or_create_by(name:, breed:)
    doge = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !doge.empty? 
      doge_data = doge[0]
      doge = self.new_from_db(doge_data)
    else 
      doge = self.create(name: name, breed: breed)
    end 
    doge
  end 
  
end