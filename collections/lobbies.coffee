
## LOBBIES
# PUBLIC
#   - name -> "Nigma's Stream"
#   - hasPassword -> false
#   - isMatchmaking -> false
#   - public -> true
#   - mod -> "fof"
#   - creator -> "Nigma" (IF isMatchmaking == false)
#   - creatorid -> "userid"
#   - radiant -> [{_id: id, name: "Quantum", avatar: "someshit"}]
#   - dire -> same thing
#   - invitedPlayers -> [user ID array]
#   - serverIP -> connection address (cached)
#   - enableGG -> enable "gg" to end function
# PRIVATE
#   - mmid -> matchmaking resolution ID
#   - status -> 0 = waiting for users, 1 = finding server, 2=configuring server, 3 = playing, 4 = done
#   - requiresFullLobby -> If admin, false. Otherwise, true.
#   - devMode -> false (set -condebug and -dev) 
@lobbies = new Meteor.Collection "lobbies"
