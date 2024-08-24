#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

FILE_PATH = 'public/memos.json'

def get_memos(file_path)
  File.open(file_path) { |file| JSON.parse(file.read) }
end

def set_memos(file_path, memos)
  File.open(file_path, 'w') { |file| JSON.dump(memos, file) }
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
  @memos = get_memos(FILE_PATH)
  @current_page = 'index'
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  memos = get_memos(FILE_PATH)
  selected_memo = memos['memos'].find { |memo| params[:id].to_i == memo['id'] }

  if selected_memo
    @title = selected_memo['title']
    @content = selected_memo['content']
    erb :detail
  else
    404
  end
end

get '/memos/:id/edit' do
  memos = get_memos(FILE_PATH)
  selected_memo = memos['memos'].find { |memo| params[:id].to_i == memo['id'] }

  if selected_memo
    @title = selected_memo['title']
    @content = selected_memo['content']
    erb :edit
  else
    404
  end
end

post '/memos' do
  title = params[:title]
  content = params[:content]

  memos = get_memos(FILE_PATH)
  id = memos['memos'].empty? ? 1 : memos['memos'][-1]['id'] + 1
  memos['memos'] << { 'id' => id, 'title' => title, 'content' => content }
  set_memos(FILE_PATH, memos)

  redirect '/memos'
end

delete '/memos/:id' do
  memos = get_memos(FILE_PATH)
  selected_memo = memos['memos'].find { |memo| params[:id].to_i == memo['id'] }

  memos['memos'].delete(selected_memo) if selected_memo

  set_memos(FILE_PATH, memos)
  redirect '/memos'
end

patch '/memos/:id' do
  title = params[:title]
  content = params[:content]

  memos = get_memos(FILE_PATH)
  selected_memo = memos['memos'].find { |memo| params[:id].to_i == memo['id'] }

  if selected_memo
    selected_memo['title'] = title
    selected_memo['content'] = content
    set_memos(FILE_PATH, memos)
    redirect "/memos/#{params[:id]}"
  else
    404
  end
end

not_found do
  erb :not_found, layout: false
end
