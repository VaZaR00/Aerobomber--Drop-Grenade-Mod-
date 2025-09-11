#define STR_PREF STR_WMT_Module_Device_
#define SSTR_N(s) $##STR_PREF##s
#define SSTR_DESC_N(s) $##STR_PREF##DESC_##s
#define SSTR(s) STR(SSTR_N(s))
#define SSTR_DESC(s) STR(SSTR_DESC_N(s))

class CfgFactionClasses
{
	class DGM
	{
		displayName="$STR_WMT_Module_Device_FactionName";
		priority=0;
		side=7;
	};
};
class ArgumentsBaseUnits;
class CfgVehicles
{
    class Logic;
    class Module_F: Logic
    {
        class ModuleDescription
        {
            class AnyBrain;
        };
    };
    class PREF(Device): Module_F
    {
        scope = 2;
        author = "Vazar";
        displayName = "$STR_WMT_Module_Device_FactionName";
        category = STR(PREFX);
        function = SFUNC(initModuleDropDevice);
        // icon = "a3\weapons_f\data\ui\icon_gl_ca.paa";
        // portrait = "a3\weapons_f\data\ui\icon_gl_ca.paa";
        icon = "a3\ui_f\data\gui\rsc\rscdisplayarsenal\cargothrow_ca.paa";
        portrait = "a3\ui_f\data\gui\rsc\rscdisplayarsenal\cargothrow_ca.paa";
        functionPriority = 2;
        isGlobal = 1;
        isTriggerActivated = 0;

        class Arguments: ArgumentsBaseUnits
        {
            class Object
            {
                displayName = SSTR(Object);
                description = SSTR_DESC(Object);
                typeName = "STRING";
                defaultValue = "";
            };
            class slotNum
            {
                displayName = SSTR(slotNum);
                description = SSTR_DESC(slotNum);
                typeName = "NUMBER";
                defaultValue = 100;
            };
            class spawnWithGren
            {
                displayName = SSTR(spawnWithGren);
                description = SSTR_DESC(spawnWithGren);
                typeName = "STRING";
                defaultValue = "HandGrenade";
            };
            class addedItems
            {
                displayName = SSTR(addedItems);
                description = SSTR_DESC(addedItems);
                typeName = "STRING";
                defaultValue = "";
            };
            class removedItems
            {
                displayName = SSTR(removedItems);
                description = SSTR_DESC(removedItems);
                typeName = "STRING";
                defaultValue = "";
            };
            class allowSetCharge
            {
                displayName = SSTR(allowSetCharge);
                description = SSTR_DESC(allowSetCharge);
                typeName = "NUMBER";
                defaultValue = 0;
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
            class spawnTempGren
            {
                displayName = SSTR(spawnTempGren);
                description = SSTR_DESC(spawnTempGren);
                typeName = "NUMBER";
                defaultValue = 1;
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
            class allowOnlyListed
            {
                displayName = SSTR(allowOnlyListed);
                description = SSTR_DESC(allowOnlyListed);
                typeName = "NUMBER";
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
            class removeChemlights
            {
                displayName = SSTR(removeChemlights);
                description = SSTR_DESC(removeChemlights);
                typeName = "NUMBER";
                defaultValue = 1;
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
            class removeSmokes
            {
                displayName = SSTR(removeSmokes);
                description = SSTR_DESC(removeSmokes);
                typeName = "NUMBER";
                defaultValue = 1;
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
        };
    };
    // Change priority to default module for create diary
    class ModuleCreateDiaryRecord_F : Module_F
    {
        functionPriority = 5;
    };
};
