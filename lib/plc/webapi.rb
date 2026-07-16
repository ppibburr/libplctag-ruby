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

    def tag params, &b
      g,pp = *params[:gateway].split(":")
      params[:gateway] = g
      params[:port] = pp
      
      v = nil
      
      plc = Plc.new(g, port: params[:port], protocol: params[:protocol], path: params[:path])
      t   = plc.tag(params[:tag], elem_count: params[:elem_count].to_i, timeout: 50, value_type: params[:type].to_sym) do |t|
        raise "" unless ["int16","int32","int8","bit","int64","uint8","uint16","uint32","uint64","float32", "float64"].index(params[:type])
        
        if params["value"]
          t[0] = params['value'].to_i
          t.write 50
        end
        
        if params['values']
          JSON.parse(params['values']).each_with_index do |val,i|
            t[i] = val
          end
          t.write 50
        end
       
        v = t.to_a
      end
      v
    end

    get "/plc/:gateway/tag/:type/:tag" do
      tag(params).to_json
    end

    post "/plc/:gateway/tags" do
      g,pp = *params[:gateway].split(":")
      params[:gateway] = g
      params[:port] = pp

      plc = Plc.new(g, port: params[:port], protocol: params[:protocol], path: params[:path])
      
      values = {}

      request.body.rewind
      tags = JSON.parse(request.body.read) rescue {}
      
      tags.each do |tag|
        t   = plc.tag(tag["name"], elem_count: tag["count"]||=1, timeout: 50, value_type: tag["type"]) do |t|
          raise "" unless ["int16","int32","int8","bit","int64","uint8","uint16","uint32","uint64","float32", "float64"].index(tag["type"])

          if tag["value"]
            t[0] = tag["value"]
            t.write 50
            t.read 50
          end
          
          if tag["values"]
            tag["values"].each_with_index do |val,i|
              t[i] = val
            end
            t.write 50
            t.read 50
          end
        
          values[tag["name"]] = {value: t[0], type: tag["type"], values: t.to_a.to_json}
        end
      end
      
      values.to_json
    end
  end
end
