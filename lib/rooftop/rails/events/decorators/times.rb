module Rooftop
  module Rails
    module Events
      module Times

        def has_running_time?
          meta_attributes[:duration].present?
        end

        def running_time
          if has_running_time?
            t = meta_attributes[:duration].to_i
            mm, ss = t.divmod(60)            #=> [4515, 21]
            hh, mm = mm.divmod(60)           #=> [75, 15]
            dd, hh = hh.divmod(24)           #=> [3, 3]
            time = ""
            if mm == 0
              time = "About #{h.pluralize(hh,'hour')}"
            elsif hh == 0
              time = "About #{h.pluralize(mm,'minute')}"
            else
              time = "About #{h.pluralize(hh, 'hour')} and #{h.pluralize(mm,'minute')}"
            end
            time
          end
        end
      end
    end
  end
end