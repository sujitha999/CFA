global class DeleteCASLBadgeScheduler Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new deleteCASLBadges());
    }
}