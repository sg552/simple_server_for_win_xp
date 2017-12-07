# encoding: utf-8
require 'socket'
class InterfacesController < ActionController::Base
  
  attr_accessor :printed_at

  def hi
    render :json => {
      :result =>  'okok'
    }
  end

  def call_socket

    # 为了解决跨域问题
    headers['Access-Control-Allow-Origin']='*'
    headers['Access-Control-Allow-Methods']='POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method']='*'
    headers['Access-Control-Allow-Headers']='Origin, X-Requested-With, Content-Type, Accept, Authorization'

    # 正文开始。
    printers = ActiveSupport::JSON.decode(params[:socket_ips])
    temp_chosen_dishes = ActiveSupport::JSON.decode(params[:chosen_dishes])
    chosen_dishes = sort_by_dish_category_id(temp_chosen_dishes)

    @dish_categories = ActiveSupport::JSON.decode(params[:dish_categories])
    Rails.logger.info printers.inspect
    Rails.logger.info chosen_dishes.inspect

    @printed_at = Time.now
    @table_name = params[:table_name].force_encoding("UTF-8")
    @comment = params[:comment]

    printers.each do |printer|

      if printer['printType'] == 1 
        print_complete_ticket(printer, chosen_dishes, @table_name)

      else 
        print_sub_ticket(printer, chosen_dishes, @table_name)
      end
    end

    render :json =>  {
			result: 'ok',
      socket_ips: printers,
      chosen_dishes: chosen_dishes
		}
  end

  NEW_LINE = "\x0A"
  CUT_PAPER = NEW_LINE * 6 + "\x1D\x56\x01"
  DOUBLE_SIZE = "\x1B\x21\x30"

  # 做好啦。git add.comment....
  def print_complete_ticket printer, chosen_dishes, table_name
    ip = printer['socketIPAddress']
    port = printer['port']
    is_print_all = printer['printType']
    Rails.logger.info "== ticket to print: #{ip}:#{port}"
    sleep 0.1
    s = TCPSocket.new(ip, port)

    sleep 0.1
    # 调整字体成为2倍大小，并且打印分割线
    s.write DOUBLE_SIZE + "=" * 24

    # 开始打印内容
    print_line s, "皇后镇餐厅总单"
    print_line s, "桌号：#{table_name}"
    print_line s, "当前时间：#{@printed_at.strftime("%Y-%m-%d %H:%M:%S")}"
    formatted_total_comment = @comment.blank? ? "无" : @comment
    print_line s, "整单备注: #{formatted_total_comment}"
    print_line s, "-" * 24
    print_line s, "菜品:" 
    chosen_dishes.each do |chosen_dish|
      formatted_comment = chosen_dish['comment'].blank? ? 
        '' : 
        "(#{chosen_dish['comment']})"
      print_line s, "#{chosen_dish['name']}  X #{chosen_dish['quantity']} #{formatted_comment}"
    end
    print_line s, "-" * 24

    # 切纸
    sleep 0.1
    s.write CUT_PAPER

    sleep 0.1
    s.close

  end

  def print_sub_ticket printer, chosen_dishes, table_name
    ip = printer['socketIPAddress']
    port = printer['port']
    is_print_all = printer['printType']
    Rails.logger.info "== ticket to print: #{ip}:#{port}"
    sleep 0.1
    s = TCPSocket.new(ip, port)

    sleep 0.1
    # 调整字体成为2倍大小
    s.write DOUBLE_SIZE + "=" * 24

    # 开始打印分单内容
    print_line s, "皇后镇餐厅分单"
    print_line s, chosen_dish['name']
    print_line s, "quanlity: #{chosen_dish['quantity']}" # + "  " + chosen_dish.unit
    print_line s, "comment: #{chosen_dish['comment']}"
    print_line s, Time.now.strftime("%Y-%m-%d %H:%M:%S")
    print_line s, "#{table_name}"

    # 切纸
    sleep 0.1
    s.write CUT_PAPER

    sleep 0.1
    s.close
  end

  def sort_by_dish_category_id(chosen_dishes)
    chosen_dishes.sort {  |x, y| 
      temp = x['category_id'] - y['category_id'] 
      result = case temp
      when temp < 0 then -1 
      when temp > 0 then 1 
      else 0 
      end
      Rails.logger.info "== in sort , result : #{result}"
      result
    }
    return chosen_dishes
  end
end
