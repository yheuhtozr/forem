json.array! @users.each do |user|
  json.extract!(user, :id, :name, :username)

  json.summary           truncate(user.summary.presence || t.j.author(community: community_name), length: 100)
  json.profile_image_url Images::Profile.call(user.profile_image_url, length: 90)
  json.following         false
end
