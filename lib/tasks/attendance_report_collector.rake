require 'open-uri'

# TODO: cleanup and factor this file

desc "Fetches new attendance reports, parses them, and enters all attendance info into DB"
task :collect_attendance_reports => :environment do
	SESSION_URL = 'http://www.diputados.gob.mx/asistencias/asistencias/'

	if LastSession.all.empty?
		# collect all reports since beginning of time

    currDate = Date.new(2010, 01, 01)
		today = Date.today

		while currDate <= today

			begin 
				io = open(SESSION_URL + currDate.strftime("%d%m%y") + ".pdf")
				reader = PDF::Reader.new(io)

				sesh = CongressSession.create(:date => currDate)

				reader.pages.each do |p|					
					lines = p.text.split("\n")
					party = nil

					lines.each do |line|

						if line =~ /^ *(Partido (([^ ]+ )*[^ ]+))$/
							party = $1
						end

						if party and line =~ /^\s*\d+\s+(([^ ]+ )*[^ ]+) +(([^ ]+ )*[^ ]+)\s*$/
              name = $1
							attendance_status = $3

              unless Congressman.find_by_name(name)
                Congressman.create(:name => name, :party => party, :start_date => currDate)
              end

              congressman = Congressman.find_by_name(name)

              attendance = Attendance.new(:status => attendance_status)
              attendance.congressman = congressman
              attendance.congress_session = sesh

              attendance.save

						end
					end
        end

        if LastSession.all.empty?
          LastSession.create(:date => currDate)
        else
          lastSession = LastSession.all.first
          lastSession.date = currDate
          lastSession.save
        end

				puts DateTime.now.to_s + " -- Processed report for session on " + currDate.strftime("%Y-%m-%d")
				currDate += 1

			rescue => e
				case e
				when OpenURI::HTTPError
					# report did not exist move on to the next
					puts DateTime.now.to_s + " -- Could not fetch report for session on " + currDate.strftime("%Y-%m-%d")
					currDate += 1
				else
					raise e
				end
			end

		end

	elsif LastSession.all.size == 1
		# collect only the newest reports
		currDate = LastSession.first.date
    currDate += 1

    today = Date.today

    while currDate <= today

      begin
        io = open(SESSION_URL + currDate.strftime("%d%m%y") + ".pdf")
        reader = PDF::Reader.new(io)

        sesh = CongressSession.create(:date => currDate)

        reader.pages.each do |p|
          lines = p.text.split("\n")
          party = nil

          lines.each do |line|

            if line =~ /^ *(Partido (([^ ]+ )*[^ ]+))$/
              party = $1
            end

            if party and line =~ /^\s*\d+\s+(([^ ]+ )*[^ ]+) +(([^ ]+ )*[^ ]+)\s*$/
              name = $1
              attendance_status = $3

              unless Congressman.find_by_name(name)
                Congressman.create(:name => name, :party => party, :start_date => currDate)
              end

              congressman = Congressman.find_by_name(name)

              attendance = Attendance.new(:status => attendance_status)
              attendance.congressman = congressman
              attendance.congress_session = sesh

              attendance.save

            end
          end
        end

        if LastSession.all.empty?
          LastSession.create(:date => currDate)
        else
          lastSession = LastSession.all.first
          lastSession.date = currDate
          lastSession.save
        end

        puts DateTime.now.to_s + " -- Processed report for session on " + currDate.strftime("%Y-%m-%d")
        currDate += 1

      rescue => e
        case e
          when OpenURI::HTTPError
            # report did not exist move on to the next
            puts DateTime.now.to_s + " -- Could not fetch report for session on " + currDate.strftime("%Y-%m-%d")
            currDate += 1
          else
            raise e
        end
      end

    end

	else
		puts DateTime.now.to_s + " -- ERROR: LastSession table has more than one entry"
	end

end
