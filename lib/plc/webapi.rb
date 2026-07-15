require 'sinatra'
require 'json'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'plc/tag'

class Plc
  class WebAPI < Sinatra::Application
    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    end

    options '*' do
      200
    end

    get "/plc/:gateway/tag/:type/:tag" do
      g,pp = *params[:gateway].split(":")
      params[:gateway] = g
      params[:port] = pp
      
      plc = Plc.new(g, port: params[:port], protocol: params[:protocol], path: params[:path])
      t   = plc.tag(params[:tag], elem_count: params[:elem_count], timeout: 50)
      t.read 50

      raise "" unless ["int16","int32","int8","bit","int64","uint8","uint16","uint32","uint64","float32", "float64"].index(params[:type])

      t.send("get_#{params[:type]}",0).to_json
    end

    post "/plc/:gateway/tags" do
      g,pp = *params[:gateway].split(":")
      params[:gateway] = g
      params[:port] = pp
      p g
      plc = Plc.new(g, port: params[:port], protocol: params[:protocol], path: params[:path])
      
      values = {}

      request.body.rewind
      tags = JSON.parse(request.body.read) rescue {}
      
      tags.each do |tag|
        t   = plc.tag(tag["name"], elem_count: tag["count"]||=1, timeout: 50)
        t.read 50

        raise "" unless ["int16","int32","int8","bit","int64","uint8","uint16","uint32","uint64","float32", "float64"].index(tag["type"])
        p tag
        if tag["value"]
          t.send("set_#{tag["type"]}",0, tag["value"])
          t.write 50
          t.read 50
          p t.send("get_#{tag["type"]}",0)
        end
        
        values[tag["name"]] = {value: t.send("get_#{tag["type"]}",0), type: tag["type"]}
      end
      
      values.to_json
    end
  end
end
