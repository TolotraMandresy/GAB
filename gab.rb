require 'json'

class GAB
    @@money= [20_000, 10_000, 5_000]
    @@units= 'Ar'
    @@sold= 400_000

    def self.main
        switch_language
        command_listening
    end

    private

    #switching language
    def self.switch_language(lang= 'mg')
        @@language= JSON.parse(File.read("./lang/#{lang.downcase}.json"))
        print "\n\n#{@@language['welcome']}";
    end

    #to show msg
    def self.show_msg(msg= @@language['unknown'])
        puts "\n#{msg}"
    end

    #read choice from console
    def self.get_choice(msg= @@language['choice'])
        print "\n#{msg}"
        return gets.chomp.downcase.strip
    end

    def self.lang_operation
        loop do
            #show all available lang
            @@language['options']['lang']['list'].each do | key, value |
                puts "\t#{key}\t\t:\t#{value}\n"
            end
    
            choice= get_choice
    
            matching= []
            @@language['options']['lang']['list'].each_key do | key |
                if key == choice
                    matching<<key
                    break
                end
            end
    
            if matching.length == 0
                show_msg
            else
                switch_language(choice)
                break
            end 
        end
    end

    def self.command_listening
        loop do    
            puts "\n\n#{@@language['presentation']}"
            
            #to show all available command
            @@language['options'].each_value do | value |
                puts "\t#{value['command']}\t\t:\t#{value['explanation']}\n"
            end
    
            #get the user's command
            choice= get_choice
        
            case choice
                when @@language['options']['lang']['command']
                    lang_operation
    
                when @@language['options']['ret']['command']
                    retire
    
                when @@language['options']['bal']['command']
                    sold
    
                when @@language['options']['add']['command']
                    add
                    
                when @@language['options']['quit']['command']
                    break
                else
                    puts "\n#{@@language['unkown']}"
            end
        end
    end

    def self.sold
        puts "\n#{@@language['options']['bal']['successMsg']} #{getAmount}"
    end

    def self.add
        val= 0
        loop do
            #enter amount
            val= get_choice("#{@@language['options']['ret']['amount']} (#{@@units}): ").to_i
            (val.to_s == val.to_s && val >= 0 && (val % @@money.last)==0 ) ? break : (puts @@language['options']['ret']['invalidAmout'])
        end
        @@sold+=val

        show_msg("#{@@language['options']['add']['successMsg']} #{getAmount(val)}")
    end

    def self.retire
        amount= 0
        loop do
            #enter amount
            amount= get_choice("#{@@language['options']['ret']['amount']} (#{@@units}): ").to_i
            show_msg("#{@@language['options']['ret']['errorMsg']}") if @@sold < amount
            (amount.to_s == amount.to_s && amount >= 0 && (amount % @@money.last)==0 && @@sold >= amount) ? break : (puts @@language['options']['ret']['invalidAmout'])
        end

        #billet number
        nbr= []

        loop do
            #show all available options
            @@language['options']['ret']['options'].each do | key, value |
                puts "\t#{key}\t\t:\t#{value}\n"
            end
    
            choice= get_choice
    
            matching= ''
            @@language['options']['ret']['options'].each_key do | key |
                if key == choice
                    matching= key
                    break
                end
            end

            case matching
                when 'min'
                    nbr= minimum(amount)
                    break
                when 'balance'
                    nbr= balanced(amount)
                    break
                else
                    show_msg
            end
        end

        @@sold-= amount
        show_msg("#{@@language['options']['ret']['successMsg']} #{getAmount(amount)}")
        show_ticket_number(nbr)
    end

    def self.show_ticket_number(nbr= [])
        puts "\n"
        for i in 0..@@money.length-1
            puts "#{getAmount(@@money[i])} : #{nbr[i]}"
        end
    end

    def self.minimum(amount)
        nbr= Array.new(@@money.length, 0)
        @@money.each_index do | i |
            nbr[i]= amount / @@money[i].to_i
            amount= amount % @@money[i].to_i
        end
        return  nbr
    end

    def self.balanced(amount)
        nbr= Array.new(@@money.length, 0)
    
        @@money.each_index do | i |
            sum= 0
            for j in i..@@money.length-1
                sum += @@money[j].to_i
            end
        
            div= amount / sum
        
            if(div != 0)
                for j in i..@@money.length-1
                    nbr[j]+= div
                end
        
                amount-= div*sum
                break
            end
        end
        
        remind= minimum(amount)
    
        for j in 0..@@money.length-1
            nbr[j]+= remind[j]
        end
    
        return nbr
    end

    def self.getAmount(amount= @@sold)
        "#{amount} #{@@units}"
    end
end

GAB.main