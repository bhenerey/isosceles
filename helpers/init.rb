module Sinatra
  module Isosceles
    module Helpers

      # def require_logged_in
      #   redirect('/sessions/new') unless is_authenticated?
      # end
      #
      # def is_authenticated?
      #   return !!session[:user_id]
      # end


      def sample_helper(count)
        "#{count} items" # or whatever
      end

      def time_since(time_in_epoch_format)
        if time_in_epoch_format == 0
          return "<div style=\"color: #ffffff; background-color: #ff0000\">N/A</div>"
        end

        time_now = Time.now.to_i
        time_since = ((time_in_epoch_format - time_now)/(60)).abs #minutes

        time_diff=""

        case time_since
        when 0..59
          time_diff= "#{time_since} min(s)"
        when 60..1440
          time_diff= "#{time_since/60} hr(s)"
        else
          time_diff= "<div style=\"color: #ffffff; background-color: #ff0000\">#{time_since/60/24} day(s)</div>"
        end

        return time_diff
        # foo_safe =  "<em>FOO</em>"
        # return foo_safe
      end

      def time_since_in_mins(time_in_epoch_format)

        time_now = Time.now.to_i
        time_since = ((time_in_epoch_format - time_now)/(60)).abs #minutes

        return time_since.to_i

      end

      def ec2_running(state)
        case state
        when "stopped"
          return "<div style=\"color: #ffffff; background-color: #ff0000\">stopped</div>"
        when "running"
          return "running"
        else
          return "N/A"
        end
      end

      def nr_health(status)
        case status
        when "green"
          return "green"
        when "orange"
          return "<div style=\"color: #ffffff; background-color: #ffa500\">orange</div>"
        when "red"
          return "<div style=\"color: #ffffff; background-color: #ff0000\">red</div>"
        else
          return "N/A"
        end
      end

    end
  end
end
