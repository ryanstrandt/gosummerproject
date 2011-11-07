class ProjectsController < ApplicationController
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  before_filter :find_page

  def index
    # @key = Digest::SHA1.hexdigest(params.collect {|k,v| [k,v]}.flatten.join('/'))
    # unless fragment_exist?(@key)
      unless params.size == 3
        conditions = basic_conditions
        unless params[:all] == 'true'
          
          if params[:id] && !params[:id].empty?
            ids = params[:id].split(',')
            condition = []
            ids.each do |id| 
              condition << "#{SpProject.table_name}.id = ?"
              conditions[1] << id
            end
            conditions[0] << '(' + condition.join(' OR ') + ')'
          end
          if params[:name] && !params[:name].empty?
            conditions[0] << "#{SpProject.table_name}.name like ?"
            conditions[1] << "%#{params[:name]}%"
          end
          if params[:city] && !params[:city].empty?
            conditions[0] << "#{SpProject.table_name}.city = ?"
            conditions[1] << params[:city]
          end
          if params[:country] && !params[:country].empty?
            countries = params[:country].split(',')
            condition = []
            countries.each do |country|
              condition << "#{SpProject.table_name}.country = ?"
              conditions[1] << '%'+country+'%'
            end
            conditions[0] << '(' + condition.join(' OR ') + ')'
          end
          # this option has two modes of access to accomodate the form post and 
          # the xml feed. params[:project][:partner] is for the form post.
          # params[:partner] is for the xml feed.
          if (params[:partner] || (params[:project] && params[:project][:partner])) && 
                !(partner = params[:partner] || params[:project][:partner]).empty?
            conditions[0] << "(#{SpProject.table_name}.primary_partner = ? OR 
                               #{SpProject.table_name}.secondary_partner = ? OR 
                               #{SpProject.table_name}.tertiary_partner = ?)"
            conditions[1] << partner
            conditions[1] << partner
            conditions[1] << partner
          end
          if params[:aoa] && !params[:aoa].empty?
            aoas = params[:aoa].split(',')
            condition = []
            aoas.each do |aoa| 
              condition << "#{SpProject.table_name}.aoa LIKE ?"
              conditions[1] << '%'+aoa+'%'
            end
            conditions[0] << '(' + condition.join(' OR ') + ')'
          end
          if params[:start_month].present?
            day = params[:start_day].present? ? params[:start_day].to_i : 1
            start_date = Time.mktime(@year, params[:start_month].to_i, day)
            conditions[0] << "#{SpProject.table_name}.start_date >= ?"
            conditions[1] << start_date.to_s(:db)
          end

          if params[:end_month] && !params[:end_month].empty?
            day = params[:end_day].present? ? params[:end_day].to_i : COMMON_YEAR_DAYS_IN_MONTH[params[:end_month].to_i]
            end_date = Time.mktime(@year, params[:end_month].to_i, day)
            conditions[0] << "#{SpProject.table_name}.end_date <= ?"
            conditions[1] << end_date
          elsif params[:start_month].present?
            end_date = Time.mktime(@year, 12, 31)
            conditions[0] << "#{SpProject.table_name}.end_date <= ?"
            conditions[1] << end_date
          end
          if params[:project_type] && !params[:project_type].empty?
            conditions[0] << "#{SpProject.table_name}" + get_project_type_condition
          end
          if params[:focus] && params[:focus].to_i != 0
            focus = SpMinistryFocus.find(params[:focus])
            build_focus_conditions(focus, conditions)
          end
          if params[:focus_name] && !params[:focus_name].empty?
            focus = SpMinistryFocus.find_by_name(params[:focus_name])
            build_focus_conditions(focus, conditions)
          end
          if params[:from_weeks] && !params[:from_weeks].empty?
            conditions[0] << "#{SpProject.table_name}.weeks >= ?"
            conditions[1] << params[:from_weeks]
          end
          if params[:to_weeks] && !params[:to_weeks].empty?
            conditions[0] << "#{SpProject.table_name}.weeks <= ?"
            conditions[1] << params[:to_weeks]
          end
          if params[:job] && !params[:job].empty?
            conditions[0] << "#{SpProject.table_name}.job = ?"
            conditions[1] << (params[:job] ? 1 : 0)
          end
        end
        conditions[0] = conditions[0].join(' AND ')
        conditions.flatten!
        if conditions[0].empty?
          @projects = []
        else
          @projects = SpProject.find(:all, 
                                      :include => [:primary_ministry_focus, :ministry_focuses],
                                      :conditions => conditions,
                                      :order => 'sp_projects.name, sp_projects.year')
        end
      end
    # end
    # you can use meta fields from your model instead (e.g. browser_title)
    # by swapping @page for @project in the line below:
    present(@page)
  end
  
  def markers
    # raise basic_conditions.flatten.inspect
    @projects = SpProject.where(basic_conditions.flatten)
    render :layout => false
  end

  def show
    @project = SpProject.find(params[:id])

    # you can use meta fields from your model instead (e.g. browser_title)
    # by swapping @page for @project in the line below:
    present(@page)
  end

protected


  def find_page
    @page = Page.where(:link_url => "/projects").first
  end
  
  def build_focus_conditions(focus, conditions)
    if focus
      condition = "(#{SpProject.table_name}.primary_ministry_focus_id = ? "
      unless focus.sp_projects.empty?
        condition += "OR #{SpProject.table_name}.id IN (#{focus.sp_projects.collect(&:id).join(',')}))"
      else
        condition += ")"
      end
      conditions[0] << condition
      conditions[1] << focus.id
    end
  end

  def get_regions
    @region_options = Region.find(:all, :order => 'region').map(&:region)
  end

  def get_project_type_condition
    if params[:project_type] == 'US'
      return ".country = 'United States'"
    else
      return ".country <> 'United States'"
    end
  end
  
  def basic_conditions
    @year = 2012
    conditions = [[],[]]
    conditions[0] << "#{SpProject.table_name}.show_on_website = 1"
    conditions[0] << "#{SpProject.table_name}.year = ? "
    conditions[0] << "#{SpProject.table_name}.project_status = 'open'"
    conditions[0] << "(#{SpProject.table_name}.current_students_men + #{SpProject.table_name}.current_students_women + #{SpProject.table_name}.current_applicants_men + #{SpProject.table_name}.current_applicants_women) < (#{SpProject.table_name}.max_student_men_applicants + #{SpProject.table_name}.max_student_women_applicants)"
    conditions[1] << @year
    conditions
  end

end
