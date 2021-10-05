class Api::V1::MypagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  require './app/classes/save_answer'
  require './app/classes/convert_month_span'

  def log
    @answer = Answer.find_by(key: params[:user_id])

    set_data = Marshal.load(Marshal.dump(@answer[:save_data]))

    keys = @answer[:save_data].keys
    keys.each do |key|
      save_answer = SaveAnswer.new({ "dateStart": DateTime.now }, key, 'kari', set_data)
      save_answer.adjust
    end

    @answer.update(key: params[:user_id], save_data: set_data)

    return_data = []
    keys.each do |key|
      book_id = key.to_s.to_sym
      grade = 1 
      school = "dummy_gakkou"

      daily_studying_time = ConvertMonthSpan.new(set_data[book_id][:studyingTime][:dailyArr], set_data[book_id][:updated_date])
      daily_answered_question = ConvertMonthSpan.new(set_data[book_id][:answeredQuestionNum][:dailyArr], set_data[book_id][:updated_date])
      daily_correct_answer = ConvertMonthSpan.new(set_data[book_id][:correctAnswerNum][:dailyArr], set_data[book_id][:updated_date])
      
      subject = set_data[book_id][:subject]
      
      studyingTime = {
        total: set_data[book_id][:studyingTime][:total],
        dailyArr: daily_studying_time.convert_span
      }
      answeredQuestionNum = {
        total: set_data[book_id][:answeredQuestionNum][:total],
        dailyArr: daily_answered_question.convert_span
      }
      
      correctAnswerNum = {
        total: set_data[book_id][:correctAnswerNum][:total],
        dailyArr: daily_correct_answer.convert_span
      }

      gold = 0
      silver = 0
      bronze = 0

      units = set_data[book_id][:units]

      units.keys.each do |key|
        if units[key][:crown] == 'gold'
          gold += 1
        elsif units[key][:crown] == 'silver'
          silver += 1
        elsif units[key][:crown] == 'bronze'
          bronze += 1
        end
      end

      return_data.push(
        { 
          drillid: book_id, 
          grade: grade, 
          school: school, 
          subject: subject, 
          crownNum: { 
            gold: gold, 
            silver: silver, 
            bronze: bronze 
          },
          studyingTime: studyingTime, 
          answeredQuestionNum: answeredQuestionNum,
          correctAnswerNum: correctAnswerNum
        }
      )
    end


    
    if @answer 
      render status: 200, json: return_data
    else
      render status: 400, json: { save_data: '失敗' }
    end
  end
end
