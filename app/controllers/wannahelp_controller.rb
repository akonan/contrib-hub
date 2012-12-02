class WannahelpController < ApplicationController
  before_filter :parameterize

  def index
    @search = Repo.search(params[:q])
    @repos = @search.result(distinct: true)
    @languages = Repo.get_languages
    gon.tags = Repo.fetch_all_tag_names
  end

  def update
    repo = Repo.find(params[:id])
    current_user.update_repo_status(repo)
    #star(repo.user, repo.name)
    redirect_to user_wannahelp_index_path(current_user)
  end

private

  def parameterize
    if params[:q].present?
      params[:q][:need_help_true] = true
      params[:q][:user_id_not_eq] = current_user.id
      if params[:undefined].present? && params[:undefined][:tags].size > 0
        params[:q][:tags_name_in] = params[:undefined][:tags]
      end
    else
      params[:q] = {
        need_help_true: true,
        user_id_not_eq: current_user.id
      }
    end
  end

  def star(user, repo)
    github = Github.new oauth_token: user.token
    github.repos.starring.starred(owner: user.github_id, repo: repo)
  end
end
