class UsersTable
  def initialize(database_connection)
    @database_connection = database_connection
  end

  def create(username, password)
    # user = username.downcase
    insert_user_sql = <<-SQL
      INSERT INTO users (username, password)
      VALUES ('#{username.downcase}', '#{password}')
      RETURNING id
    SQL

    @database_connection.sql(insert_user_sql).first["id"]
  end

  def find(user_id)
    find_sql = <<-SQL
      SELECT * FROM users
      WHERE id = #{user_id}
    SQL

    @database_connection.sql(find_sql).first
  end

  def find_user(username)
    find_sql = <<-SQL
      SELECT id FROM users
      WHERE username = '#{username}'
    SQL

    @database_connection.sql(find_sql)
  end

  def users(order=[])
    users_sql = <<-SQL
      SELECT username, id FROM users
    SQL

    if order == "asc"
      users_sql += <<-SQL
      ORDER BY username ASC
      SQL
    elsif order == "desc"
      users_sql += <<-SQL
      ORDER BY username DESC
      SQL
    end

    @database_connection.sql(users_sql)
  end

  def find_by(username, password)
    find_by_sql = <<-SQL
      SELECT * FROM users
      WHERE username = '#{username.downcase}'
      AND password = '#{password}'
    SQL

    @database_connection.sql(find_by_sql).first
  end

  def delete_user(username)
    delete_user_sql = <<-SQL
      DELETE FROM users
      WHERE username = '#{username}'
    SQL

    @database_connection.sql(delete_user_sql)
  end

end
