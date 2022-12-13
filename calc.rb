require 'strscan'
class Calc
    def initialize
        begin
            @formula = ARGV[0]
            # puts @formula
        rescue
            puts "計算式がありません。"
        end
        scanner = StringScanner.new(@formula.chomp)
        # puts scanner

        @keywords = {
            '+' => :add,
            '-' => :sub,
            '*' => :mul,
            '/' => :div,
            '(' => :left_parn,
            ')' => :right_parn
        }

        @scanner = []
        tokenize(scanner)
        # p @scanner

        p eval(expression) #結果を出力
    end

    def tokenize(scanner)
        scan = scanner.scan(/(\d+|[\+\-\*\/()])*/)
        # puts scan
        @num = []
        scan.each_char do |s|
            # p s
            case s
            when /[\+\-\*\/()]/ # 符号の場合
                @scanner << (@num.join).to_i if @num.size >= 1
                @scanner << @keywords[s]
                @num.clear if @num.size >= 1
            when /\d/ # 数字の場合
                @num << s.to_i # 一度@numに入れる。2桁以上の数値に対応するため
            end
        end
        @scanner << (@num.join).to_i if @num.size >= 1 #式の最後に数字があったら
        # p "#{@scanner}, tokenize"
    end


    def expression()
        result = term()
        token = get_token()
        while token == :add or token == :sub
            result = [token, result, term()]
            p result
            token = get_token()
        end
        unget_token(token)
        
        return result
    end

    def term()
        result = factor()
        token = get_token()
        while token == :mul or token == :div
            result = [token, result, factor()]
            p result
            token = get_token()
        end
        unget_token(token)

        return result
    end

    def factor()
        token = get_token
        if token.is_a?(Numeric) # 数字だったら
            result = token
        elsif token == :left_parn #（ だったら
            result = expression()
            token = get_token # 閉じカッコを取り除く(使用しない)
            if token != :right_parn # ) なかったら
                raise Exception, "構文エラー"
            else
                # p token
            end
        end

        return result
    end

    def eval(exp)
        if exp.instance_of?(Array)
            case exp[0]
            when :add
                return eval(exp[1]) + eval(exp[2])
            when :sub
                return eval(exp[1]) - eval(exp[2])
            when :mul
                return eval(exp[1]) * eval(exp[2])
            when :div
                begin
                    return eval(exp[1]) / eval(exp[2])
                rescue => e
                    puts e.message
                end
            end
        else
            return exp
        end
    end

    def parse()
        expression()
    end

    # ソースコードの先頭から、次のtokenを一つ切り出して返す。
    def get_token()
        if @scanner[0]
            token = @scanner[0]
            @scanner = @scanner[1..-1]

            return token
        end
    end

    # tokenを受け取り、ソースコードの先頭にそれを押し戻す。
    def unget_token(token)
        if token
            @scanner.unshift(token)
        end
    end
end

Calc.new