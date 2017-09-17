"use strict";

function OnKillEvent( event )
{
	var teamPanel = $.GetContextPanel();
	var teamId = $.GetContextPanel().GetAttributeInt( "team_id", -1 );
	if ( teamId !== event.team_id )
		return;
	var panel2 = $('#TeamScorePanel');
	panel2.text = event.team_kills.toString();

	if ( event.victory )
	{
		teamPanel.SetHasClass( "victory", true );
		teamPanel.SetHasClass( "close_to_victory", false );
		teamPanel.SetHasClass( "very_close_to_victory", false );
		pointsToWinPanel.text = $.Localize( "#PointsToWin_Victory", pointsToWinPanel );
	}
	else if ( event.very_close_to_victory ) 
	{
		teamPanel.SetHasClass( "victory", false );
		teamPanel.SetHasClass( "close_to_victory", false );
		teamPanel.SetHasClass( "very_close_to_victory", true );
		pointsToWinPanel.text = $.Localize( "#PointsToWin_VeryCloseToVictory", pointsToWinPanel );
	}
	else if ( event.close_to_victory )
	{
		teamPanel.SetHasClass( "victory", false );
		teamPanel.SetHasClass( "close_to_victory", true );
		teamPanel.SetHasClass( "very_close_to_victory", false );
		pointsToWinPanel.text = $.Localize( "#PointsToWin_CloseToVictory", pointsToWinPanel );
	}
}


(function()
{
//	$.Msg( "overthrow_scoreboard_team_overlay" );

	var teamPanel = $.GetContextPanel();
	GameEvents.Subscribe( "kill_event", OnKillEvent );
})();
