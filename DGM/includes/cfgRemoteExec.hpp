class CfgRemoteExec
{
    class Functions
    {
        class DGM_fnc_dropDevice { allowedTargets = 0; };
        class DGM_fnc_removeDropDevice { allowedTargets = 0; };
        class DGM_fnc_setSlotsNumber { allowedTargets = 0; };
		class DGM_fnc_remoteCall { allowedTargets = 0; };
    };
    class Commands
	{
		mode = 2;

		class call
		{
			allowedTargets = 0;
			jip = 0;
		};
		class setShotParents
		{
			allowedTargets = 0;
			jip = 0;
		};
	};
};

