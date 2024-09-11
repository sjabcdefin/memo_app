#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

def connect_db
  PG.connect(dbname: 'memos', user: 'user_name', password: 'user_password')
end

def close_db(conn)
  conn.close
end

def load_all_memos(conn)
  conn.exec('SELECT * FROM memos')
end

def load_memo(conn, id)
  result = conn.exec_params('SELECT * FROM memos WHERE id = $1', [id])
  if result.ntuples.zero?
    nil
  else
    result[0]
  end
end

def create_memo(conn, title, content)
  conn.exec_params('INSERT INTO memos (title, content) VALUES ($1, $2)', [title, content])
end

def delete_memo(conn, id)
  conn.exec_params('DELETE FROM memos WHERE id = $1', [id])
end

def update_memo(conn, id, title, content)
  result = conn.exec_params('UPDATE memos SET title = $2, content =$3 WHERE id = $1', [id, title, content])
  result.cmd_tuples
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  conn = connect_db
  @memos = load_all_memos(conn)
  @current_page = 'index'
  close_db(conn)
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  conn = connect_db
  selected_memo = load_memo(conn, params[:id].to_i)
  close_db(conn)

  if selected_memo
    @title = selected_memo['title']
    @content = selected_memo['content']
    erb :detail
  else
    404
  end
end

get '/memos/:id/edit' do
  conn = connect_db
  selected_memo = load_memo(conn, params[:id].to_i)
  close_db(conn)

  if selected_memo
    @title = selected_memo['title']
    @content = selected_memo['content']
    erb :edit
  else
    404
  end
end

post '/memos' do
  conn = connect_db
  create_memo(conn, params[:title], params[:content])
  close_db(conn)

  redirect '/memos'
end

delete '/memos/:id' do
  conn = connect_db
  delete_memo(conn, params[:id].to_i)
  close_db(conn)

  redirect '/memos'
end

patch '/memos/:id' do
  conn = connect_db
  update_rows = update_memo(conn, params[:id].to_i, params[:title], params[:content])
  close_db(conn)

  if update_rows.positive?
    redirect "/memos/#{params[:id]}"
  else
    404
  end
end

not_found do
  erb :not_found, layout: false
end
