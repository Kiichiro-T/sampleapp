class ReceiptPdf < Prawn::Document

    def initialize
      super(
        page_size: 'A4'
      )
      stroke_axis
      font "app/assets/fonts/ipaexm.ttf"
      create_box
    end

    def create_box
      bounding_box([0, 700], :width => 500, :height => 250) do
        #stroke_bounds
        move_down 10
        create_title
        move_down 5
        create_date
        move_down 10
        create_name
        move_down 10
        create_debt
        move_down 10
        create_tadashi
        move_down 40
        create_uchiwake
       end
    end

    def create_title
      text '領収書', align: :center, size: 25
    end

    def create_date
      text "#{Time.now.strftime("%Y年%m月%d日")}", align: :right, right_padding: 10
    end

    def create_name
      text '豊泉喜一郎　　様', size: 15
    end

    def create_debt
      text "￥10,000-", align: :center, size: 25
    end

    def create_tadashi
      text "但し　○○代として", align: :center,　size: 15
      text "上記正に領収いたしました", align: :center,　size: 15
    end

    def create_uchiwake
      text "内訳", size: 15
      move_down 5
      text "税抜金額　　￥10,000-"
      move_down 5
      text "消費税額　　　　 800-"
    end


    
  end